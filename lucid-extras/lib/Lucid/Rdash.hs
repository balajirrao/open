{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
{-# LANGUAGE ScopedTypeVariables#-}

module Lucid.Rdash (indexPage) where

import qualified Data.Text as T
import Data.List

import Control.Monad

import Lucid.Bootstrap3

import Lucid

rdashCSS, sidebarMain, sidebarTitle :: Monad m => HtmlT m ()

rdashCSS = link_ [rel_ "stylesheet",
                  href_  "http://cdn.filopodia.com/rdash-ui/1.0.1/css/rdash.css"]

ariaHidden :: Term arg result => arg -> result
ariaHidden = term "aria-hidden"

sidebarTitle = span_ "NAVIGATION"
sidebarMain  = a_ [href_ "#"] $ do
  "Dashboard"
  span_ [class_ "menu-icon glyphicon glyphicon-transfer"] (return ())

mkPageWrapperOpen :: (Monad m) => HtmlT m () -> HtmlT m () -> HtmlT m ()
mkPageWrapperOpen sbw cw = div_ [id_ "page-wrapper", class_ "open"] $ sbw >> cw

mkSidebarWrapper :: (Monad m) => HtmlT m () -> HtmlT m () -> HtmlT m ()
mkSidebarWrapper sb sbf = div_ [id_ "sidebar-wrapper"] $ sb >> sbf

mkSidebar :: (Monad m) => HtmlT m () -> HtmlT m () -> [HtmlT m ()] -> HtmlT m ()
mkSidebar sbm sbt sbl = ul_ [class_ "sidebar"] $ do
  li_ [class_ "sidebar-main", id_ "toggle-sidebar"] sbm
  li_ [class_ "sidebar-title"] sbt
  forM_ sbl $ \l -> do
    li_ [class_ "sidebar-list"] l

mkSidebarItem :: (Monad m) => HtmlT m () -> T.Text -> HtmlT m ()
mkSidebarItem s icon = a_ [href_ "#"] $ s >> do
  span_ [class_ $ T.append icon " menu-icon"] (return ())

mkSidebarFooter :: (Monad m) => HtmlT m () -> HtmlT m ()
mkSidebarFooter footerItems = div_ [class_ "sidebar-footer"] footerItems

mkHead :: (Monad m) => String -> HtmlT m ()
mkHead title = head_ $ do
  meta_ [charset_ "UTF-8"]
  meta_ [name_ "viewport", content_ "width=device-width"] -- TODO: add attribute initial-scale=1
  title_ (toHtml title)
  rdashCSS
  cdnFontAwesome
  cdnCSS
  cdnJqueryJS
  cdnBootstrapJS

mkBody :: (Monad m) => HtmlT m () -> HtmlT m ()
mkBody pgw = body_ [class_ "hamburg"] pgw

mkPageContent :: Monad m => HtmlT m () -> HtmlT m ()
mkPageContent = div_ [id_ "content-wrapper"] . div_ [class_ "page-content"]

mkHeaderBar :: Monad m => [HtmlT m ()] -> HtmlT m ()
mkHeaderBar cols = div_ [class_ "row header"] (rowEven XS cols)

mkUserBox :: Monad m => [HtmlT m ()] -> HtmlT m ()
mkUserBox xs = div_ [class_ "user pull-right"] $ sequence_ xs

mkItemDropdown :: Monad m => T.Text -> HtmlT m () -> HtmlT m ()
mkItemDropdown icon x = div_ [class_ "item dropdown"] $ do
  a_ [ class_ "dropdown-toggle"
     , term "data-toggle" $ "dropdown"
     , href_ "#"] (i_ [class_ icon, ariaHidden "true"] (return ()))
  x

mkDropdownMenu :: Monad m => HtmlT m () -> [[HtmlT m ()]] -> HtmlT m ()
mkDropdownMenu hdr xs = ul_ [class_ "dropdown-menu dropdown-menu-right"] $ sequence_ dividedItems
  where
    mkLi = li_ . (a_ [href_ "#"])
    items = map (map mkLi) xs
    dividedItems = (li_ [class_ "dropdown-header"] hdr) : li_ [class_ "divider"] (return ()) :
      (concat $ intersperse [li_ [class_ "divider"] (return ())] items)

mkIndexPage :: (Monad m) => HtmlT m () -> HtmlT m () -> HtmlT m ()
mkIndexPage hd body = html_ [lang_ "en"] $ hd >> body

mkMetaTitle :: Monad m => HtmlT m () -> HtmlT m ()
mkMetaTitle = div_ [class_ "page"]

mkMetaBreadcrumbLinks :: Monad m => HtmlT m () -> HtmlT m ()
mkMetaBreadcrumbLinks = div_ [class_ "breadcrumb-links"]

mkMetaBox :: Monad m => [HtmlT m ()] -> HtmlT m ()
mkMetaBox = div_ [class_ "meta pull-left"] . sequence_

mkAlerts :: Monad m => [HtmlT m ()] -> HtmlT m ()
mkAlerts l = mkCol [(XS, 12)] (sequence_ l)

mkAlert :: Monad m => T.Text -> HtmlT m () -> HtmlT m ()
mkAlert alertType = div_ [class_ $ T.unwords ["alert", alertType]]

mkWidgetIcon :: Monad m => T.Text -> T.Text -> HtmlT m ()
mkWidgetIcon color icon =
  div_ [class_$ T.unwords ["widget-icon pull-left", color]] $ i_ [class_ icon] (return ())

mkWidgetContent :: Monad m => HtmlT m () -> HtmlT m () -> HtmlT m ()
mkWidgetContent title comment =
  div_ [class_ "widget-content pull-left"] $ do
  div_ [class_ "title"] title
  div_ [class_ "comment"] comment

mkWidget :: Monad m => HtmlT m () -> HtmlT m () -> HtmlT m ()
mkWidget wIcon wContent =
  div_ [class_ "widget"] $
  div_ [class_ "widget-body"] $
  wIcon >> wContent >> div_ [class_ "clearfix"] (return ())

mkWidgets :: Monad m => [HtmlT m ()] -> HtmlT m ()
mkWidgets widgets =
  div_ [class_ "row"] $
  forM_ widgets $ \widget -> mkCol [(XS, 12), (MD, 6), (LG, 3)] widget

indexPage :: (Monad m) => HtmlT m ()
indexPage = do
  mkIndexPage hd body
  where

    -- SIDEBAR
    dashboardSI = mkSidebarItem (toHtml "Dashboard") "fa fa-tachometer"
    tablesSI    = mkSidebarItem (toHtml "Tables") "fa fa-table"
    sb = mkSidebar sidebarMain sidebarTitle [dashboardSI, tablesSI]
    footerContent =
      rowEven XS
      [ a_ [href_ "https://github.com/rdash/rdash-barebones", target_ "blank_"] "Github"
      , a_ [href_ "#", target_ "blank_"] "About"
      , a_ [href_ "#"] "Support"]
    sbf = mkSidebarFooter footerContent
    sbw = mkSidebarWrapper sb sbf

    -- Header Bar
    userMenu = mkItemDropdown "fa fa-user-o" $ mkDropdownMenu "Joe Bloggs" [["Profile", "Menu Item"], ["Logout"]]
    bellMenu = mkItemDropdown "fa fa-bell-o" $ mkDropdownMenu "Notifications" [["Server Down!"]]
    userBox = mkUserBox [userMenu, bellMenu]
    metaBox = mkMetaBox [mkMetaTitle "Dashboard", mkMetaBreadcrumbLinks "Home / Dashboard"]
    hb = mkHeaderBar [metaBox, userBox]

    -- Main Content
    alerts = mkAlerts [ mkAlert "alert-success" "Thanks for visiting! Feel free to create pull requests to improve the dashboard!"
                      , mkAlert "alert-danger" "Found a bug? Create an issue with as many details as you can."]
    widgets = mkWidgets $
      [ mkWidget (mkWidgetIcon "green" "fa fa-users") (mkWidgetContent (toHtml "80") (toHtml "Users"))
      , mkWidget (mkWidgetIcon "red" "fa fa-tasks") (mkWidgetContent (toHtml "16") (toHtml "Servers"))
      , mkWidget (mkWidgetIcon "orange" "fa fa-sitemap") (mkWidgetContent (toHtml "225") (toHtml "Documents"))
      , mkWidget (mkWidgetIcon "blue" "fa fa-support") (mkWidgetContent (toHtml "62") (toHtml "Tickets"))]

    pcw = mkPageContent (hb >> alerts >> widgets)

    pgw = mkPageWrapperOpen sbw pcw

    body = mkBody pgw

    hd = mkHead ("Dashboard" :: String)
